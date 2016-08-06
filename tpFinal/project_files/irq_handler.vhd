----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:50:01 07/04/2016 
-- Design Name: 
-- Module Name:    irq_handler - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity irq_handler is
port ( clk: in std_logic;
		reset: in std_logic;
		serial_in : in std_logic_vector(7 downto 0);
		switches_in: in std_logic_vector (3 downto 0);
		serial_present: in std_logic;
		switches_present: in std_logic;
		pico_ack_in: in std_logic;
		pico_read_strobe: in std_logic;
		pico_id_port_in: in std_logic_vector (7 downto 0);
		irq_out: out std_logic;
		data_out: out std_logic_vector (7 downto 0));
end irq_handler;

architecture Behavioral of irq_handler is
component registro is
   generic ( width : integer := 4 );
	port ( rin: in std_logic_vector(width - 1 downto 0);
		carga: in std_logic;
		clk: in std_logic;
		reset: in std_logic;
		rout: out std_logic_vector(width - 1 downto 0));
end component registro;

type IRQ_MEF is (INIT, DATA_ENTERED, PROCESS_WHO, PROCESS_DATA, ACK);

signal serial_reg : std_logic_vector (7 downto 0);
signal switches_reg : std_logic_vector (3 downto 0);
signal reg_who_in, reg_who_out : std_logic_vector (1 downto 0);
signal reg_who_load: std_logic;
signal irq_signal : std_logic;

signal ci_state: IRQ_MEF;

begin

reg_who_in <= serial_present & switches_present;
reg_who_load <= serial_present or switches_present;

reg_serial: registro
 generic map (width => 8) 
 port map(rin=>serial_in,
			carga=>serial_present,
			clk => clk,
			reset=> reset,
			rout => serial_reg);
			
reg_switch: registro
 generic map (width => 4) 
 port map(rin=>switches_in,
			carga=>switches_present,
			clk => clk,
			reset=> reset,
			rout => switches_reg);

reg_who: registro
 generic map (width => 2) 
 port map(rin=>reg_who_in,
			carga=>reg_who_load,
			clk => clk,
			reset=> reset,
			rout => reg_who_out);

process(clk, reset)
begin
	if rising_edge(clk) then
		case ci_state is
			when INIT =>
				irq_out <= '0';
				data_out <= (others=>'0');
				if reg_who_load = '1' then ci_state <= PROCESS_WHO; end if;
			when DATA_ENTERED =>
				irq_out <= reg_who_load;
				data_out <= "000000" & reg_who_out;
				ci_state <= PROCESS_WHO;
			when PROCESS_WHO =>
				if pico_ack_in = '1' then 
					irq_out <= '0';
				else 
					irq_out <= reg_who_load;
				end if;
				data_out <= "000000" & reg_who_out;
				if pico_read_strobe = '1' then ci_state <= PROCESS_DATA; end if;
			when PROCESS_DATA =>
				irq_out <= '0';
				case reg_who_out is
					when "10" => data_out <= serial_reg;
					when "01" => data_out <= "0000" & switches_reg;
					when "11" => data_out <= serial_reg;
					when others  => data_out <= (others => '0');
				end case;
				if pico_read_strobe = '1' then ci_state <= ACK; end if;
			when ACK =>
				irq_out <= '0';
				data_out <= (others=>'0');
				if reg_who_load = '0' then ci_state <= INIT; end if;
			when others =>
			irq_out <= '0';
			data_out <= (others=>'0');
			ci_state <= INIT;
		end case;
	end if;
end process;

end Behavioral;


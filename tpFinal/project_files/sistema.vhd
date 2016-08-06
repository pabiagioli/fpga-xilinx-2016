----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:22:24 07/02/2016 
-- Design Name: 
-- Module Name:    sistema - Behavioral 
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

entity sistema is
port (clk: in std_logic;
		reset: in std_logic;
		in_serie: in std_logic; --std_logic_vector(7 downto 0)
		switch: in std_logic_vector(3 downto 0);
		boton: in std_logic;
		led_out: out std_logic_vector(7 downto 0));
end sistema;

architecture Behavioral of sistema is

 component antirebote is
	port(clk: in std_logic;
		  reset: in std_logic;
		  p: in std_logic;
		  antiR: out std_logic);
 end component antirebote;

 component divisorFreq is
	port(clk: in std_logic;
			reset: in std_logic;
			clk_4800: out std_logic);
 end component divisorFreq;
 component uart_rx is
	Port (            serial_in : in std_logic;
                       data_out : out std_logic_vector(7 downto 0);
                    read_buffer : in std_logic;
                   reset_buffer : in std_logic;
                   en_16_x_baud : in std_logic;
            buffer_data_present : out std_logic;
                    buffer_full : out std_logic;
               buffer_half_full : out std_logic;
                            clk : in std_logic);
 end component uart_rx;
 
 component uart_tx is
	Port (            data_in : in std_logic_vector(7 downto 0);
                 write_buffer : in std_logic;
                 reset_buffer : in std_logic;
                 en_16_x_baud : in std_logic;
                   serial_out : out std_logic;
                  buffer_full : out std_logic;
             buffer_half_full : out std_logic;
                          clk : in std_logic);
 end component uart_tx;

 component irq_handler is
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
 end component irq_handler;
 

 component top_PB is
	Port (      
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
 end component top_PB;
 
 component registro is
   generic ( width : integer := 4 );
	port ( rin: in std_logic_vector(width - 1 downto 0);
		carga: in std_logic;
		clk: in std_logic;
		reset: in std_logic;
		rout: out std_logic_vector(width - 1 downto 0));
end component registro;
 
 
 signal salida_boton, divisor_out, pico_read_strobe,salida_interrupt, pico_ack, pico_write_strobe, pico_irq_in: std_logic;
 signal salida_uart, pico_in_port, pico_port_id, pico_out_port: std_logic_vector(7 downto 0);
 
 signal out_load: std_logic;
 signal out_value: std_logic_vector(7 downto 0);
begin

 antireb: antirebote
	port map(p => boton,
				clk => clk,
				reset => reset,
				antiR => salida_boton);
				
 divFreq: divisorFreq
	port map(clk=>clk, reset=>reset, clk_4800=>divisor_out);
		
 uartRX: uart_rx
		port map(clk=>clk, 
			en_16_x_baud=> divisor_out, 
			read_buffer =>pico_read_strobe, 
			reset_buffer =>reset, 
			serial_in => in_serie,
			data_out=>salida_uart, 
			buffer_data_present => salida_interrupt);	

 ci: irq_handler
	port map(clk => clk,
				reset=>reset,
				serial_in=> salida_uart,
				serial_present=> salida_interrupt,
				switches_present => salida_boton,
				switches_in => switch,
				irq_out=> pico_irq_in,
				data_out=> pico_in_port,
				pico_read_strobe => pico_read_strobe,
				pico_id_port_in => pico_port_id,
				pico_ack_in => pico_ack);
				
 pico: top_PB
		port map(clk=>clk, 
			reset=> reset, 
			interrupt_ack=>pico_ack,
			in_port=>pico_in_port,
			interrupt =>pico_irq_in,
			read_strobe=>pico_read_strobe,
			write_strobe=>pico_write_strobe,
			port_id=>pico_port_id,
			out_port=> pico_out_port);

 regOut: registro
	generic map (width=> 8)
	port map (rin=> pico_out_port,
				 carga=> out_load,
				 clk => clk,
				 reset => reset,
				 rout => led_out); 
				 
process(clk)
begin
if falling_edge(clk) then
	if pico_port_id = "00000001" and pico_write_strobe = '1' then
		out_load <= '1';
	else 
		out_load <= '0';
	end if;
end if;
end process;

end Behavioral;


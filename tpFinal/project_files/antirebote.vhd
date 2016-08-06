----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:51:45 06/04/2016 
-- Design Name: 
-- Module Name:    antirebote - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity antirebote is
port (clk: in std_logic;
		reset: in std_logic;
		p: in std_logic;
		antiR: out std_logic);
end antirebote;

architecture Behavioral of antirebote is
signal p_buffer: std_logic_vector (11 downto 0);
begin

process(clk, reset)
begin 
	if reset = '1' then 
		p_buffer <= (others => '0');
		elsif rising_edge(clk) then
			p_buffer <= p_buffer(10 downto 0) & p;
		end if;
end process;

process(clk, reset)
begin
	if reset = '1' then
		antiR <= '0';
	elsif rising_edge(clk) then
		case p_buffer is
			when x"FFF" => antiR <= '1';
			when x"000" => antiR <= '0';
			when others => antiR <= '0';
		end case;
	end if;
end process;

end Behavioral;


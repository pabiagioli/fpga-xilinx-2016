----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:50:22 06/11/2016 
-- Design Name: 
-- Module Name:    registro_8bit - Behavioral 
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
entity registro is
generic ( width : integer := 4);

port ( rin: in std_logic_vector(width - 1 downto 0);
		carga: in std_logic;
		clk: in std_logic;
		reset: in std_logic;
		rout: out std_logic_vector(width - 1 downto 0));
end registro;

architecture Behavioral of registro is
begin
	process(clk,reset)
	begin
		if reset = '1' then
			rout <= (others => '0');
		elsif rising_edge(clk) then
			if carga = '1' then
				rout <= rin;
			end if;
		end if;
	end process;
end Behavioral;


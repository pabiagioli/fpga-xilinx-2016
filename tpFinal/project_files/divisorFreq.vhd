----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:02:03 06/11/2016 
-- Design Name: 
-- Module Name:    divisorFreq - Behavioral 
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

entity divisorFreq is
port(clk : in std_logic;
	reset: in std_logic;
	clk_4800: out std_logic);
	
end divisorFreq;

architecture Behavioral of divisorFreq is

begin
	process(clk, reset)
	variable cuenta: integer range 0 to 700;
	begin
		if reset='1' then cuenta := 0;
		elsif rising_edge(clk) then cuenta:= cuenta + 1;
			if cuenta < 651 then clk_4800 <= '0';
			elsif cuenta = 651 then
				clk_4800 <= '1'; cuenta := 0; 
			end if;
		end if;
	end process;
end Behavioral;


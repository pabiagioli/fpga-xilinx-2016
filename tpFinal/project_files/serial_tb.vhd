--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   23:06:43 08/05/2016
-- Design Name:
-- Module Name:   C:/Users/pablo/Desktop/fpga2016/tpFinal/serial_tb.vhd
-- Project Name:  tpFinal
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: sistema
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY serial_tb IS
END serial_tb;

ARCHITECTURE behavior OF serial_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT sistema
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         in_serie : IN  std_logic;
         switch : IN  std_logic_vector(3 downto 0);
         boton : IN  std_logic;
         led_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;

	 component uart_tx
    Port (            data_in : in std_logic_vector(7 downto 0);
                 write_buffer : in std_logic;
                 reset_buffer : in std_logic;
                 en_16_x_baud : in std_logic;
                   serial_out : out std_logic;
                  buffer_full : out std_logic;
             buffer_half_full : out std_logic;
                          clk : in std_logic);
    end component uart_tx;

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal in_serie : std_logic := '0';
	signal data_in : std_logic_vector(7 downto 0) := (others => '0');
	signal write_buffer : std_logic := '0';
	signal en_16_x_baud : std_logic := '0';
	signal buffer_full : std_logic;
   signal switch : std_logic_vector(3 downto 0) := (others => '0');
   signal boton : std_logic := '0';

 	--Outputs
   signal led_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

   tx: uart_tx port map (
			 data_in => data_in,
			 write_buffer => write_buffer,
			 reset_buffer => reset,
			 en_16_x_baud => en_16_x_baud,
			 serial_out=> in_serie,
			 buffer_full => buffer_full,
			 clk=>clk);

	-- Instantiate the Unit Under Test (UUT)
   uut: sistema PORT MAP (
          clk => clk,
          reset => reset,
          in_serie => in_serie,
          switch => switch,
          boton => boton,
          led_out => led_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
       -- hold reset state for 100 ns.
      wait for 100 ns;

      wait for clk_period*10;

      -- insert stimulus here
		switch <= "0011";
		boton <= '1';
		wait for clk_period*100;
		boton <= '0';
		wait for clk_period*1000;
		assert led_out = "00000110";
		switch <= "0001";
		boton <= '1';
		wait for clk_period*100;
		boton <= '0';
		wait for clk_period*1000;
		assert led_out = "00000011";
		switch <= "0000";
		data_in <= "01110001";
		write_buffer <= '1';
		en_16_x_baud <= '1';
		boton <= '0';
		wait for 1 ms;
		data_in <= "00000000";
		write_buffer <= '0';
		en_16_x_baud <= '0';
		boton <= '0';
      wait for 1000 ms;
		assert led_out = "11111111";
		wait;
   end process;

END;

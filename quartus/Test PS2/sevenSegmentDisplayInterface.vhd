--sevenSegmentDisplayIntergface port, for four digits seven segment displays!
--
--This program recives a binary number, and then prints the number to the seven segment display
--the number would be printed as hexadecimal. The program does not support neither negative nor
--decimal numbers, to be upgraded.
--
--The code has been tested for the Cyclone IV (EP4CE6E22C8N)
--
--Based on the explanations form: https://www.fpga4student.com/2017/09/vhdl-code-for-seven-segment-display.html
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;

entity sevenSegmentDisplayInterface is
	generic(refresh_counter_lenght: positive := 20);
	port (
		clk: in std_logic; --The clock of the cpu
		rst: in std_logic; --The reset signal of the cpu

		number: in std_logic_vector(15 downto 0); --The number to be displayed

		digits_activated: out std_logic_vector(3 downto 0); --Every digit if it is activated or not, active_low
		segments_activated: out std_logic_vector(6 downto 0) --Every segment if is activates or not, active_low
	);
end sevenSegmentDisplayInterface;

architecture Behavioral of sevenSegmentDisplayInterface is

--The digit to be displayed right now
signal digit_bcd: std_logic_vector(3 downto 0);

--Creating 10.5ms refresh period
signal refresh_counter: std_logic_vector(refresh_counter_lenght-1 downto 0);

--Two bits obtained from the last positions of the refresh_counter to count the digit that we are going
--to display right now
signal digit_activating_counter: std_logic_vector(1 downto 0);

begin
	
	--Process to select the segments that are going to be displayed depending of the digit we are displaying now
	process(digit_bcd)
	begin
		case digit_bcd is
		when "0000" => segments_activated <= "0000001"; -- "0"
		when "0001" => segments_activated <= "1001111"; -- "1"
		when "0010" => segments_activated <= "0010010"; -- "2"
		when "0011" => segments_activated <= "0000110"; -- "3"
		when "0100" => segments_activated <= "1001100"; -- "4"
		when "0101" => segments_activated <= "0100100"; -- "5"
		when "0110" => segments_activated <= "0100000"; -- "6"
		when "0111" => segments_activated <= "0001111"; -- "7"
		when "1000" => segments_activated <= "0000000"; -- "8"
		when "1001" => segments_activated <= "0000100"; -- "9"
		when "1010" => segments_activated <= "0001000"; -- "a"
		when "1011" => segments_activated <= "1100000"; -- "b"
		when "1100" => segments_activated <= "0110001"; -- "C"
		when "1101" => segments_activated <= "1000010"; -- "d"
		when "1110" => segments_activated <= "0110000"; -- "E"
		when "1111" => segments_activated <= "0111000"; -- "F"
		end case;
	end process;

	--Process to generate refresh period of 10.5ms, you can make it faster by changing the bits
	--that are taken from the refresh_counter, make sure to change also the definition of the
	--std_logic_vector to match up with the nuew values.
	process(clk, rst)
	begin 
		if(rst='0') then
			refresh_counter <= (others => '0');
		elsif(rising_edge(clk)) then
			refresh_counter <= refresh_counter + 1;
		end if;
	end process;
	digit_activating_counter <= refresh_counter(refresh_counter_lenght-1 downto refresh_counter_lenght-2);

	-- 4-to-1 MUX to generate anode activating signals for 4 digits 
	process(digit_activating_counter)
	begin
		case digit_activating_counter is
		when "00" =>
			--Activating LED1 and deactivating LED2, LED3, LED4
			digits_activated <= "0111"; 

			--The first hex digit of the 16-bit number
			digit_bcd <= number(15 downto 12);

		when "01" =>
			--Activating LED2 and deactivating LED1, LED3, LED4
			digits_activated <= "1011";

			--The second hex digit of the 16-bit number
			digit_bcd <= number(11 downto 8);

		when "10" =>
			--Activating LED3 and deactivating LED2, LED1, LED4
			digits_activated <= "1101"; 

			--The third hex digit of the 16-bit number
			digit_bcd <= number(7 downto 4);

		when "11" =>
			--Activating LED4 and deactivating LED2, LED3, LED1
			digits_activated <= "1110";

			--The fourth hex digit of the 16-bit number 
			digit_bcd <= number(3 downto 0);

		end case;
	end process;

end Behavioral;
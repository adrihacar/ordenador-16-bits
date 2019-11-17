--ps2Interface port, for keyboard input only!
--
--This program converts the serial input from the ps2 to a usefull 8Bits indicating the key/combination of keys
--pressed, a valid variable, which indicates if the data recived is valid or not, and an error varible
--which indicates if there was an error in the data recived.
--
--The code has been tested for the Cyclone IV (EP4CE6E22C8N)
--
--Based loosely on ps2_intf.vhd and UK101keyboard.vhd form the MultiComp project: https://github.com/douggilliland/MultiComp
--
--The code is for the 16Bit computer, by Pablo Rivero Lazaro
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

entity ps2Interface is
generic (filter_length: positive := 8); --The number of bits that need to be recived by the ps2 clock to be treated like a one or a cero
port(

	clk: in std_logic; --The clock of the cpu
	rst: in std_logic; --The reset signal of the cpu

	ps2_clk: in std_logic; --The clock of the ps2 port
	ps2_data: in std_logic; --The data of the ps2 port

	data: out std_logic_vector(7 downto 0); --The output data in paralel obtained from the series data recived
	data_valid: out std_logic; --High if the data recived is valid
	data_error: out std_logic --High if there was an error, the data variable would be "00000000"
	);
end ps2Interface;

architecture Behavioral of ps2Interface is

--Subtype declared to create a filtering device for the clock
subtype filter_t is std_logic_vector(filter_length-1 downto 0);

--Clock filtering signal, needs at least 8 continuout ones or zeros to consider the reception as a 1 or a 0
signal clk_filter: filter_t;

--Is one if the filtered clock indicates a one
signal ps2_clk_in: std_logic;

--Is the last data recived
signal ps2_data_in: std_logic;

--Goes high when a clock falling edge is detected
signal clk_edge: std_logic;

--The counter that indicates where in the reciving serial data we are in
signal bit_count: unsigned(3 downto 0);

--The shift register that stores the serial data recived
signal shiftreg: std_logic_vector(8 downto 0);

--The parity we claculate to test if is 1, meaning that there are a even number of 1's
signal parity: std_logic;

begin
	
	--Main process to detect falling edges of the ps2 clock, and saving the data recived
	process(clk, rst)
	begin
		if rst = '0' then
			ps2_clk_in <= '1';
			ps2_data_in <= '1';
			clk_filter <= (others => '1');
			clk_edge <= '0';

		elsif rising_edge(clk) then
			ps2_data_in <= ps2_data; --Saving the data just recived

			--Shift register the clock pulse to save at least eight continuous high or low pulses
			clk_filter <= ps2_clk & clk_filter(clk_filter'high downto 1);
			clk_edge <= '0';

			if clk_filter = filter_t'(others => '1') then --filtered clock is high
				ps2_clk_in <= '1';

			elsif clk_filter = filter_t'(others => '0') then --filtered clock is low
				--If now there is low at the ps2_clock and the last reading was hight, we just have detected a falling edge
				if ps2_clk_in = '1' then
					clk_edge <= '1';

				end if;
				ps2_clk_in <= '0';

			end if;
		end if;
	end process;

	--Secondary process to save the data recived by the keyboard
	process(clk, rst)
	begin
		if rst = '0' then
			bit_count <= (others => '0');
			shiftreg <= (others => '0');
			parity <= '0';
			data <= (others => '0');
			data_valid <= '0';
			data_error <= '0';

		elsif rising_edge(clk) then
			--Clear data flags
			data_valid <= '0';
			data_error <= '0';

			if clk_edge = '1' then --If the ps2 clock has recently made a falling edge, we have a new bit for the keyboard to process

				if bit_count = 0 then --We havent counted any bit
					parity <= '0';

					if ps2_data_in = '0' then
						bit_count <= bit_count + 1;

					end if;
				else
					
					if bit_count < 10 then --We are reciving the 8 bits of data
						bit_count <= bit_count + 1;

						--Adding the new data recived to the shift register of data
						shiftreg <= ps2_data_in & shiftreg(shiftreg'high downto 1);

						parity <= parity xor ps2_data_in; --Calculate parity xoring the old parity with the new data. We use even 1's parity

					elsif ps2_data_in = '1' then --Valid stop bit

						bit_count <= (others => '0'); --back to the begining
						if parity = '1' then --Parity correct
							data <= shiftreg(7 downto 0);
							data_valid <= '1';

						else --Parity is not correct
							data_error <= '1';

						end if;

					else --Invalid stop bit
						bit_count <= (others => '0'); --back to the begining
						data_error <= '1';

					end if;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

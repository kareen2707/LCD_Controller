-- Register submodule
-- Creation date: 12/12/2018
-- Version: 1.0


library ieee;
use ieee.std_logic_1164.all;

entity Registers is
	port(
		Clk	:	in  std_logic;
		Reset_n	: in std_logic;
		
		--Avalon Slave Signals
		AS_Address			: 	in std_logic_vector(2 downto 0);
		AS_ChipSelect		: 	in std_logic;
		AS_Write			:	in std_logic;
		AS_Read 			:	in std_logic;
		AS_WriteData 		:	in std_logic_vector(31 downto 0);
		AS_ReadData 		:	out std_logic_vector(31 downto 0);
		
		--Signals connected to Master Controller
		
		Reading				: 	in std_logic;
		AcqAddress			: 	out unsigned(31 downto 0);
		AcqBurstCount		:	out unsigned(31 downto 0);
		AcqLength			: 	out unsigned(31 downto 0);
		Start				: 	out std_logic; 
		Currently_writing	:	out std_logic; 
		
		--Signals connected to LCD_Control
		Cmd_Address			:	out unsigned(31 downto 0);
		Cmd_Data			: 	out unsigned(31 downto 0);
		Ack_Write			: 	in std_logic 
	);
end entity Registers;

architecture behavioural of Registers is
	
	
Begin
	
	AS_process: Process (Clk, Reset_n)
	Begin
		if Reset_n = '0' then
			AcqAddress <= (others =>'0');
			AcqLength <= (others =>'0');
			AcqBurstCount <= (others =>'0');
			Cmd_Address <= (others =>'0');
			Cmd_Data <= (others =>'0');
			
		elsif rising_edge(Clk) then
		 	if AS_ChipSelect = '1' then
				if AS_Write = '1' then
					case AS_Address is
						when "000" => AcqAddress <= unsigned(AS_WriteData);
						when "001" => AcqLength <= unsigned(AS_WriteData);
						when "010" => AcqBurstCount <= unsigned(AS_WriteData(1 downto 0));
						when "011" => Start <= AS_WriteData(0);
						when "100" => Cmd_Address <= unsigned(AS_WriteData);
						when "101" => Cmd_Data <= unsigned(AS_WriteData);
						when "110" => Currently_writing <= AS_WriteData(0);
					end case;
				end if;
			
				if AS_Read = '1' then
					case AS_Address is
						when "000" => AS_ReadData <= std_logic_vector(AcqAddress);
						when "001" => AS_ReadData <= std_logic_vector(AcqLength);
						when "010" => AS_ReadData <= std_logic_vector(AcqBurstCount);
						when "011" => AS_ReadData(0) <= Start;
						when "100" => AS_ReadData <= std_logic_vector(Cmd_Address);
						when "101" => AS_ReadData <= std_logic_vector(Cmd_Data);
						when "110" => AS_ReadData(0) <= not(Reading); 
						when "111" => AS_ReadData(0) <= Ack_Write;
					end case;
				end if;
			end if;
		end if;	
	end process acquisition_process;
end ;
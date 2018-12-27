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
		AcqAddress			: 	out std_logic_vector(31 downto 0);
		AcqBurstCount		:	out std_logic_vector(31 downto 0);
		Start				: 	out std_logic; 
		Currently_writing	:	out std_logic; 
		
		--Signals connected to LCD_Control
		Cmd_Address			:	out std_logic_vector(31 downto 0);
		Cmd_Data			: 	out std_logic_vector(31 downto 0);
		Ack_Write			: 	in std_logic 
	);
end entity Registers;

architecture behavioural of Registers is
	
	
Begin
	
	acquisition_process: Process (Clk, Reset_n)
	Begin
		if Reset_n = '0' then
			AcqAddress <= (others =>'0');
			AcqLength <= (others =>'0');
			Cmd_Address <= (others =>'0');
			Cmd_Data <= (others =>'0');
			
		elsif rising_edge(Clk) then
		 if AS_ChipSelect = '1' then
			if AS_Write = '1' then
				case AS_Address is
					when '000' => AcqAddress <= AS_WriteData;
					when '001' => AcqLength <= AS_WriteData;
					when '010' => Start <= AS_WriteData(0);
					when '011' => Cmd_Address <= AS_WriteData;
					when '100' => Cmd_Data <= AS_WriteData;
					when '101' => Currently_writing <= AS_WriteData(0);
				end case;
			end if;
			
			if AS_Read = '1' then
				case AS_Address is
					when '000' => AS_ReadData <= AcqAddress;
					when '001' => AS_ReadData <= AcqLength;
					when '010' => AS_ReadData(0) <= Start;
					when '011' => AS_ReadData <= Cmd_Address;
					when '100' => AS_ReadData <= Cmd_Data;
					when '101' => AS_ReadData(0) <= Reading; 
					when '110' => AS_ReadData(0) <= Ack_Write;
				end case;
			end if;
			
		end if;
		
	end acquisition_process;
	
end ;
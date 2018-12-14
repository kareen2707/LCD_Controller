-- Register submodule
-- Creation date: 12/12/2018
-- Version: 1.0


library ieee;
use ieee.std_logic_1164.all;

entity Master_Controller is
	port(
		Clk	:	in  std_logic;
		Reset_n	: in std_logic;
		
		--Configuration registers
		Address				: 	in std_logic_vector(31 downto 0);
		Length_read			: 	in std_logic_vector(31 downto 0);
		Start		 		:	in std_logic;
		AllowToRead			:	in std_logic;
		Reading	 			:	out std_logic;
		
		--Signals connected to FIFO
		
		FIFO_full			: 	in std_logic;
		WrFIFO				: 	in std_logic;
		WrData				:	out std_logic_vector(31 downto 0);
		
		
		--Avalon Master Signals
		AM_Address			: 	out std_logic_vector(31 downto 0);
		AM_WaitRequest		: 	in std_logic;
		AS_Read 			:	out std_logic;
		AS_BurstCount 		:	out std_logic_vector(2 downto 0);
		AS_ReadDataValid 	:	in std_logic;
		AS_ReadData			:	in std_logic_vector(31 downto 0);
	);
end entity Master_Controller;

architecture behavioural of Registers is

-- State definition

type state is (Idle, WaitData, ReadData, WriteData );
signal CurrentState, NextState : state;

-- Auxiliar signals
signal counter : integer range 0 to 4 :=0;
	
	
Begin
	
	NextSate_process: Process (Clk, Reset_n)
	Begin
		if Reset_n = '0' then
			CurrentState <= idle;
			
		elsif rising_edge(Clk) then
		 if AS_ChipSelect = '1' then
			if AS_Write = '1' then
				case AS_Address is
					when '000' => AcqAddress <= AS_WriteData;
					when '001' => AcqLength <= AS_WriteData;
					when '010' => Start <= AS_WriteData(0);
					when '011' => Cmd_Address <= AS_WriteData;
					when '100' => Cmd_Data <= AS_WriteData;
					when '101' => AllowToRead <= AS_WriteData(0);
				end case;
			end if;
			
			if AS_Read = '1' then
				case AS_Address is
					when '000' => AS_ReadData <= AcqAddress;
					when '001' => AS_ReadData <= AcqLength;
					when '010' => AS_ReadData(0) <= Start;
					when '011' => AS_ReadData <= Cmd_Address;
					when '100' => AS_ReadData <= Cmd_Data;
					when '101' => AS_ReadData(0) <= AllowToRead;
					when '110' => AS_ReadData(0) <= Ack_Write;
					when '111' => AS_ReadData(0) <= Reading;
				end case;
			end if;
			
		end if;
		
	end acquisition_process;
	
end ;
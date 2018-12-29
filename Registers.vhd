-- Register submodule
-- Creation date: 12/12/2018
-- Last modification: 29/12/2018
-- Version: 2.0


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

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
		AcqBurstCount		:	out unsigned(1 downto 0);
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

	Signal TmpAddress		: unsigned(31 downto 0);
	Signal TmpLength		: unsigned (31 downto 0);
	Signal TmpBurstCount	: unsigned (1 downto 0);
	Signal Tmp_CmdAddress	: unsigned(31 downto 0);
	Signal Tmp_CmdData		: unsigned (31 downto 0);
	
	
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
						when "000" => TmpAddress <= unsigned(AS_WriteData);
						when "001" => TmpLength <= unsigned(AS_WriteData);
						when "010" => TmpBurstCount <= unsigned(AS_WriteData(1 downto 0));
						when "011" => Start <= AS_WriteData(0);
						when "100" => Tmp_CmdAddress <= unsigned(AS_WriteData);
						when "101" => Tmp_CmdData <= unsigned(AS_WriteData);
						when "110" => Currently_writing <= AS_WriteData(0);
						when others => null;
					end case;
					AcqAddress <= TmpAddress;
					AcqLength <= TmpLength;
					AcqBurstCount <= TmpBurstCount;
					Cmd_Address <= Tmp_CmdAddress;
					Cmd_Data <= Tmp_CmdData;
				end if;
			
				if AS_Read = '1' then
					case AS_Address is
						when "000" => AS_ReadData <= std_logic_vector(TmpAddress);
						when "001" => AS_ReadData <= std_logic_vector(TmpLength);
						when "010" => AS_ReadData(1 downto 0) <= std_logic_vector(TmpBurstCount);
						--when "011" => AS_ReadData(0) <= Start;
						when "100" => AS_ReadData <= std_logic_vector(Tmp_CmdAddress);
						when "101" => AS_ReadData <= std_logic_vector(Tmp_CmdData);
						when "110" => AS_ReadData(0) <= not(Reading); 
						when "111" => AS_ReadData(0) <= Ack_Write;
						when others => null;
					end case;
				end if;
			end if;
		end if;	
	end process AS_process;
end ;
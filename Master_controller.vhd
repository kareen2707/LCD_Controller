-- Master_Controller submodule
-- Creation date: 12/12/2018
-- Last modification: 1/1/2019
-- Version: 3.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Master_Controller is
	port(
		Clk	:	in  std_logic;
		Reset_n	: 	in std_logic;
		
		--Configuration registers
		Address				: 	in unsigned(31 downto 0);
		DataLength			: 	in unsigned(31 downto 0);
		BurstCount			: 	in unsigned(2 downto 0);
		Start		 		:	in std_logic; -- Maybe we don't need it
		Currently_writing		:	in std_logic; 
		Reading	 			:	out std_logic;
		
		--Signals connected to FIFO
		
		FIFO_Almost_full		:	in std_logic;
		WrFIFO				: 	out std_logic;
		WrData				:	out std_logic_vector(31 downto 0);
		
		
		--Avalon Master Signals
		AM_WaitRequest			: 	in std_logic;
		AM_ReadDataValid 		:	in std_logic;
		AM_ReadData			:	in std_logic_vector(31 downto 0);
		AM_Address			: 	out std_logic_vector(31 downto 0);
		AM_Read 			:	out std_logic;
		AM_BurstCount 			:	out std_logic_vector(2 downto 0));
end entity Master_Controller;

architecture behavioural of Master_Controller is

-- State definition

type state is (Idle, WaitPermission, WaitFifo, WaitData, WriteData);
signal CurrentState,NextState: state;

-- Auxiliar constants and signals 

constant burstsize		: integer := 4;
--burstsize <= to_integer(BurstCount);
constant max_length		: integer := 1;
--max_lenght <= to_integer(DataLength);
signal en_burstcount 	: std_logic;
signal en_datacount		: std_logic;
signal burstcounter 	: integer range 0 to burstsize := 0; -- Counter used for AM_ReadDataValid	
signal datacounter		: integer range 0 to max_length := 0;
Signal TmpAddress		: unsigned (31 downto 0);
Signal TmpLength		: unsigned (31 downto 0);
Signal TmpBurstCount	: unsigned (2 downto 0);

	
Begin
	NS_process: Process(Clk, Reset_n)
	begin 
		if Reset_n = '0' then
			CurrentState <= Idle;
		elsif rising_edge(clk) then
			CurrentState <= NextState;
			if en_burstcount = '1' then 
				burstcounter <= burstcounter+1;
			else 
				burstcounter <= 0;
			end if;

			if burstcounter = burstsize then
				burstcounter <= 0;
				--if en_datacount = '1' then
					datacounter <= datacounter + 1;
				--else
				--	datacounter <= 0;
				--end if;
			end if;

			--if en_datacount = '0' then
			--	datacounter <= 0;
			--end if;
	  end if;
	end process;

	AM_process: Process (CurrentState, Start, AM_ReadDataValid, Currently_writing, FIFO_almost_full, burstcounter, datacounter, AM_WaitRequest)

	Begin

	NextState <= CurrentState;
	en_burstcount <= '0';
	en_datacount <= '0';
	Reading <= '0';
	AM_Read <= '0';
	WrFIFO <= '0';
	WrData <= (others => '0');
	TmpAddress <= (others => '0');
	TmpBurstCount <= (others => '0');
	TmpLength <= (others => '0');

	case CurrentState is
		when Idle =>
				
			if Start = '1' then
				TmpAddress <= Address;
				--TmpLength <= DataLength;
				TmpBurstCount <= BurstCount;
				NextState <= WaitPermission;
			end if;

		when WaitPermission =>
			if Currently_writing = '0' then
				NextState <= WaitFifo;
				AM_Address <= std_logic_vector(TmpAddress);
				AM_BurstCount <= std_logic_vector(TmpBurstCount);
			end if;

		when WaitFifo =>

			if FIFO_Almost_full = '0' then 
				NextState <= WaitData;
				WrFIFO <= '1';					--Notifying we want to write into the FIFO
				AM_Read <= '1';					--Initializing the reading process
				Reading <= '1';					--Notifying the SRAM module is been used by LCD Controller
			end if;
				
		when WaitData =>

			if AM_ReadDataValid = '1' then		--We have readed a new data from SRAM
				en_burstcount <= '1';
				en_datacount <= '1';
				WrData <= AM_ReadData;
			end if;

			if datacounter = max_length then
				Reading <= '0';
				AM_Read <= '0';
				WrFIFO <= '0';
				NextState <= Idle;
			elsif burstcounter = burstsize then
				NextState <= WriteData;
				TmpAddress <= TmpAddress + 1;
			end if;
			
		when WriteData =>

			if AM_WaitRequest = '0' then
				AM_Read <= '0';
				WrFIFO <= '0';
				Reading <= '0';
				NextState <= WaitPermission;
			end if;
			
	end case;	

end process AM_process;
	
end ;
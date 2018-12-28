-- Master_Controller submodule
-- Creation date: 12/12/2018
-- Version: 1.0


library ieee;
use ieee.std_logic_1164.all;

entity Master_Controller is
	port(
		Clk	:	in  std_logic;
		Reset_n	: in std_logic;
		
		--Configuration registers
		Address				: 	in unsigned(31 downto 0);
		BurstCount			: 	in unsigned(31 downto 0);
		Start		 		:	in std_logic;
		Currently_writing	:	in std_logic; 
		Reading	 			:	out std_logic;
		
		--Signals connected to FIFO
		
		FIFO_Almost_full	:	in std_logic;
		WrFIFO				: 	out std_logic;
		WrData				:	out std_logic_vector(31 downto 0);
		
		
		--Avalon Master Signals
		AM_WaitRequest		: 	in std_logic;
		AM_ReadDataValid 	:	in std_logic;
		AM_ReadData			:	in std_logic_vector(31 downto 0);
		AM_Address			: 	out std_logic_vector(31 downto 0);
		AM_Read 			:	out std_logic;
		AM_BurstCount 		:	out std_logic_vector(2 downto 0)
	);
end entity Master_Controller;

architecture behavioural of Registers is

-- State definition

type state is (Idle, WaitFifo, WaitData, WriteData, AcqData );
signal CurrentState : state;

-- Auxiliar signals
signal counter : integer range 0 to 4 :=0;
	
	
Begin
	
	AM_process: Process (Clk, Reset_n)
	Begin
		if Reset_n = '0' then
			CurrentState <= idle;
			Reading <= '0';
			WrFIFO <= '0';
			WrData <= (others => '0');
			AM_Address <= (others => '0');
			AM_BurstCount <= (others => '0');
			AM_Read <= '0';
			
		elsif rising_edge(Clk) then
		 
		case CurrentState is
			when Idle =>
				AM_Read <= '0';
				WrFIFO <= '0';
				Reading <= '0';
				if Currently_writing = '0' then		--Start when the Camera Controller is not using the SRAM module
					CurrentState <= WaitFifo;
					AM_Address <= std_logic_vector(Address);
					AM_BurstCount <= std_logic_vector(BurstCount);
					
				end if;

			when WaitFifo =>

				if FIFO_Almost_full = '0' then 
					CurrentState <= WaitData;
					WrFIFO <= '1';					--Notifying we want to write into the FIFO
					AM_Read <= '1';					--Initializing the reading process
					Reading <= '1';					--Notifying the SRAM module is been used by LCD Controller
				
			when WaitData =>

				if BurstCount = X"0000_0000" then	--We have readed all the data
					CurrentState <= Idle;
				elsif AM_ReadDataValid = '1' then	--We have readed a new data from SRAM
					CurrentState <= WriteData;
					WrData <= AM_ReadData;			--Each reading contains information of 2 pixels (each pixel = 16b)
				end if;
			
			when WriteData =>

				if AM_WaitRequest = '0' then
					CurrentState <= AcqData;
					--Needed to complete?

			when AcqData =>

				if AM_ReadDataValid = '0' then
					CurrentState <= WaitData;
					Reading <= '0';
					if BurstCount /= 1 then
						BurstCount <= BurstCount - 1;
					else
					BurstCount <= BurstCount;
					end if;
				end if;
			end case;

		end if;
		
	end acquisition_process;
	
end ;
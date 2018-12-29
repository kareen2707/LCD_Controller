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
		DataLength			: 	in unsigned(31 downto 0);
		BurstCount			: 	in unsigned(1 downto 0);
		Start		 		:	in std_logic; -- Maybe we don't need it
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

type state is (Idle, WaitPermission, WaitFifo, WaitData, WriteData, AcqData );
signal CurrentState : state;

-- Auxiliar constants and signals 

constant burstsize	: integer := to_integer(BurstCount);
signal en_count 	: std_logic;
signal counter 		: integer range 0 to burstsize-1 :=0; -- Counter used for AM_ReadDataValid	
	
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
					if DataLength /= X"0000_0000" then	--Starting if length is higher than zero
						CurrentState <= WaitPermission;
					end if;

				when WaitPermission =>
					if Currently_writing = '0' then
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
					end if;
				
				when WaitData =>

					if AM_ReadDataValid = '1' then		--We have readed a new data from SRAM
						CurrentState <= WriteData;
						WrData <= AM_ReadData;			--Each reading contains information of 2 pixels (each pixel = 16b)
					end if;
			
				when WriteData =>

					if AM_WaitRequest = '0' then
						CurrentState <= AcqData;
						AM_Read <= '0';
						WrFIFO <= '0';
					end if;

				when AcqData =>

					if AM_ReadDataValid = '0' then
						CurrentState <= WaitPermission;
						Reading <= '0';
						if DataLength /= 1 then
							Address <= Address + 1;
							DataLength <= DataLength - 1;
						else
							Address <= Address;
							DataLength <= DataLength;
						end if;
					end if;
			end case;

		end if;
		
	end process AM_process;
	
end ;
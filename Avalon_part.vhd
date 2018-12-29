LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

entity Avalon_part is
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
		
        --Signals connected to FIFO
		
		FIFO_Almost_full		:	in std_logic;
		WrFIFO				: 	out std_logic;
		WrData				:	out std_logic_vector(31 downto 0);
		
		--Avalon Master Signals
		AM_WaitRequest		: 	in std_logic;
		AM_ReadDataValid 	:	in std_logic;
		AM_ReadData			:	in std_logic_vector(31 downto 0);
		AM_Address			: 	out std_logic_vector(31 downto 0);
		AM_Read 			:	out std_logic;
		AM_BurstCount 		:	out std_logic_vector(1 downto 0)
    );
end Avalon_part;
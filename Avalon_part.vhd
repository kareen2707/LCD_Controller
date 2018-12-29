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
		
		FIFO_Almost_full	:	in std_logic;
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

architecture behavioural of Avalon_part is

    component Registers port(
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
    end component;

    component Master_controller port(
        Clk	:	in  std_logic;
		Reset_n	: 	in std_logic;
		
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
		AM_BurstCount 	    :	out std_logic_vector(1 downto 0)
    );
    end component;

    -- Auxiliar signals used for interconnecting components

    signal aux_Address		        : unsigned(31 downto 0);
	signal aux_Length		        : unsigned (31 downto 0);
    signal aux_BurstCount	        : unsigned (1 downto 0);
    signal aux_Currently_writing    : std_logic;
    signal aux_Reading              : std_logic; 
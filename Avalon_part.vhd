-- Avalon_part module result of joining Master_controller.vhd and Registers.vhd
-- Creation date: 29/12/2018
-- Last modification: -
-- Version: 1.0

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all;

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
        
        --Signals connected to LCD_Control
		Cmd_Address			:	out unsigned(31 downto 0);
		Cmd_Data			: 	out unsigned(31 downto 0);
		Ack_Write			: 	in std_logic; 
		
		--Avalon Master Signals
		AM_WaitRequest		: 	in std_logic;
		AM_ReadDataValid 	:	in std_logic;
		AM_ReadData			:	in std_logic_vector(31 downto 0);
		AM_Address			: 	out std_logic_vector(31 downto 0);
		AM_Read 			:	out std_logic;
		AM_BurstCount 		:	out std_logic_vector(2 downto 0)
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
		AcqBurstCount		:	out unsigned(2 downto 0);
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
		BurstCount			: 	in unsigned(2 downto 0);
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
		AM_BurstCount 	    :	out std_logic_vector(2 downto 0)
    );
    end component;

    -- Auxiliar signals used for interconnecting components

    signal aux_Address		        : unsigned(31 downto 0);
	signal aux_Length		        : unsigned (31 downto 0);
    signal aux_BurstCount	        : unsigned (2 downto 0);
    signal aux_Currently_writing    : std_logic;
    signal aux_Reading              : std_logic; 
    signal aux_Start                : std_logic;
    signal aux_Ack_write            : std_logic;

    begin
        Registers_comp : Registers
        port map (
            Clk => Clk,
            Reset_n => Reset_n,
            AS_Address => AS_Address,
		    AS_ChipSelect => AS_ChipSelect,
		    AS_Write => AS_Write,
		    AS_Read => AS_Read,
		    AS_WriteData => AS_WriteData,
            AS_ReadData => AS_ReadData,
            --Signals connected to Master Controller
            Reading	=> aux_Reading,
		    AcqAddress	=> aux_Address,		
		    AcqBurstCount	=> aux_BurstCount,	
		    AcqLength	=> aux_Length,	
		    Start	=> aux_Start,	 
		    Currently_writing	=> aux_Currently_writing,	
		    --Signals connected to LCD_Control
		    Cmd_Address	=> Cmd_Address,
		    Cmd_Data => Cmd_Data,
		    Ack_Write => aux_Ack_write

        );

        Master_controller_comp : Master_controller
        port map(
            Clk	=> Clk,
            Reset_n	=> Reset_n,
            --Configuration registers
            Address	=> aux_Address,
            DataLength => aux_Length,
            BurstCount => aux_BurstCount,
            Start => aux_Start,
            Currently_writing => aux_Currently_writing, 
            Reading => aux_Reading,
            --Signals connected to FIFO
            FIFO_Almost_full => FIFO_Almost_full,
            WrFIFO	=> WrFIFO,
            WrData	=> 	WrData,		
            --Avalon Master Signals
            AM_WaitRequest	=> 	AM_WaitRequest,
            AM_ReadDataValid => AM_ReadDataValid,	
            AM_ReadData	=> AM_ReadData,		
            AM_Address => AM_Address,			
            AM_Read => AM_Read,		
            AM_BurstCount => AM_BurstCount	    
        );

    end behavioural;

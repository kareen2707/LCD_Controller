LIBRARY ieee  ; 
LIBRARY std  ; 
USE ieee.NUMERIC_STD.all  ; 
USE ieee.std_logic_1164.all  ; 
USE ieee.std_logic_textio.all  ; 
USE ieee.std_logic_unsigned.all  ; 
USE std.textio.all  ; 
ENTITY tb_Avalon_part  IS 
END ; 
 
ARCHITECTURE tb_Avalon_part_arch OF tb_Avalon_part IS
  SIGNAL AS_Address   :  std_logic_vector (2 downto 0)  ; 
  SIGNAL Cmd_Address   :  UNSIGNED (31 downto 0)  ; 
  SIGNAL AM_ReadData   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL Cmd_Data   :  UNSIGNED (31 downto 0)  ; 
  SIGNAL FIFO_Almost_full   :  STD_LOGIC  ; 
  SIGNAL WrFIFO   :  STD_LOGIC  ; 
  SIGNAL AM_BurstCount   :  std_logic_vector (1 downto 0)  ; 
  SIGNAL Reset_n   :  STD_LOGIC  ; 
  SIGNAL AS_WriteData   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL AM_Read   :  STD_LOGIC  ; 
  SIGNAL Ack_Write   :  STD_LOGIC  ; 
  SIGNAL AS_ReadData   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL Clk   :  STD_LOGIC  ; 
  SIGNAL AM_Address   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL AM_ReadDataValid   :  STD_LOGIC  ; 
  SIGNAL AM_WaitRequest   :  STD_LOGIC  ; 
  SIGNAL WrData   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL AS_Write   :  STD_LOGIC  ; 
  SIGNAL AS_ChipSelect   :  STD_LOGIC  ; 
  SIGNAL AS_Read   :  STD_LOGIC  ; 
  COMPONENT Avalon_part  
    PORT ( 
      AS_Address  : in std_logic_vector (2 downto 0) ; 
      Cmd_Address  : out UNSIGNED (31 downto 0) ; 
      AM_ReadData  : in std_logic_vector (31 downto 0) ; 
      Cmd_Data  : out UNSIGNED (31 downto 0) ; 
      FIFO_Almost_full  : in STD_LOGIC ; 
      WrFIFO  : out STD_LOGIC ; 
      AM_BurstCount  : out std_logic_vector (1 downto 0) ; 
      Reset_n  : in STD_LOGIC ; 
      AS_WriteData  : in std_logic_vector (31 downto 0) ; 
      AM_Read  : out STD_LOGIC ; 
      Ack_Write  : in STD_LOGIC ; 
      AS_ReadData  : out std_logic_vector (31 downto 0) ; 
      Clk  : in STD_LOGIC ; 
      AM_Address  : out std_logic_vector (31 downto 0) ; 
      AM_ReadDataValid  : in STD_LOGIC ; 
      AM_WaitRequest  : in STD_LOGIC ; 
      WrData  : out std_logic_vector (31 downto 0) ; 
      AS_Write  : in STD_LOGIC ; 
      AS_ChipSelect  : in STD_LOGIC ; 
      AS_Read  : in STD_LOGIC ); 
  END COMPONENT ; 
BEGIN
  DUT  : Avalon_part  
    PORT MAP ( 
      AS_Address   => AS_Address  ,
      Cmd_Address   => Cmd_Address  ,
      AM_ReadData   => AM_ReadData  ,
      Cmd_Data   => Cmd_Data  ,
      FIFO_Almost_full   => FIFO_Almost_full  ,
      WrFIFO   => WrFIFO  ,
      AM_BurstCount   => AM_BurstCount  ,
      Reset_n   => Reset_n  ,
      AS_WriteData   => AS_WriteData  ,
      AM_Read   => AM_Read  ,
      Ack_Write   => Ack_Write  ,
      AS_ReadData   => AS_ReadData  ,
      Clk   => Clk  ,
      AM_Address   => AM_Address  ,
      AM_ReadDataValid   => AM_ReadDataValid  ,
      AM_WaitRequest   => AM_WaitRequest  ,
      WrData   => WrData  ,
      AS_Write   => AS_Write  ,
      AS_ChipSelect   => AS_ChipSelect  ,
      AS_Read   => AS_Read   ) ; 



-- "Clock Pattern" : dutyCycle = 50
-- Start Time = 0 ns, End Time = 1 us, Period = 20 ns
  Process
	Begin
	 clk  <= '0'  ;
	wait for 20 ns ;
-- 10 ns, single loop till start period.
	for Z in 1 to 49
	loop
	    clk  <= '1'  ;
	   wait for 20 ns ;
	    clk  <= '0'  ;
	   wait for 20 ns ;
-- 990 ns, repeat pattern in loop.
	end  loop;
	 clk  <= '1'  ;
	wait for 10 ns ;
-- dumped values till 1 us
	wait;
 End Process;


-- "Rest of signals"
-- Start Time = 0 ns, End Time = 1 us
  Process
	Begin 					--Here the PWM must be '0' cause the nReset is activated
      	 AS_ChipSelect <= '0' ; 
      	 AS_WriteData  <= (others => '0'); 
      	 Reset_n  <= '0' ; 
      	 AS_Address  <= (others => '0') ; 
      	 AS_Write  <= '0';

	wait for 30 ns ; 
	 
	 Reset_n  <= '1' ; 
	 AS_ChipSelect <= '1' ; 
	 
      	
--	wait for 20 ns; 
--	 
--	 Write  <= '1';      	 
--	 Address  <= (others => '0') ; 
--	 WriteData  <= "01111111"; 		--Here we're gonna start to write the period_pwm     	 
--	wait for 20 ns; 
--
--	 Write  <= '0';
--	  
--	wait for 20 ns; 			--Here we're gonna start to write the dutycycle
--
--	 Write  <= '1';
--	 WriteData  <= "00010100"; 
--	 Address  <= "000010" ; 
--
--	wait for 500 ns;
--	 Write  <= '1';
--	 WriteData  <= "01000100"; 
--	 Address  <= "000010" ; 
--	 --WriteData  <= (others => '0'); 
--	 --Address  <= "000011" ; 
--      	 
--	wait;
 End Process;
END;

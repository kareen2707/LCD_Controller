LIBRARY ieee  ; 
LIBRARY std  ; 
USE ieee.NUMERIC_STD.all  ; 
USE ieee.std_logic_1164.all  ; 
USE ieee.std_logic_textio.all  ; 
USE ieee.std_logic_unsigned.all  ; 
USE std.textio.all  ; 
ENTITY tb_Master_Controller  IS 
END ; 
 
ARCHITECTURE tb_Master_Controller_arch OF tb_Master_Controller IS
  SIGNAL BurstCount   :  UNSIGNED (2 downto 0)  ; 
  SIGNAL Reading   :  STD_LOGIC  ; 
  SIGNAL AM_ReadData   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL FIFO_Almost_full   :  STD_LOGIC  ; 
  SIGNAL WrFIFO   :  STD_LOGIC  ; 
  SIGNAL AM_BurstCount   :  std_logic_vector (2 downto 0)  ; 
  SIGNAL Reset_n   :  STD_LOGIC  ; 
  SIGNAL AM_Read   :  STD_LOGIC  ; 
  SIGNAL Clk   :  STD_LOGIC  ; 
  SIGNAL AM_Address   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL AM_ReadDataValid   :  STD_LOGIC  ; 
  SIGNAL Currently_writing   :  STD_LOGIC  ; 
  SIGNAL WrData   :  std_logic_vector (31 downto 0)  ; 
  SIGNAL AM_WaitRequest   :  STD_LOGIC  ; 
  SIGNAL DataLength   :  UNSIGNED (31 downto 0)  ; 
  SIGNAL Address   :  UNSIGNED (31 downto 0)  ; 
  SIGNAL Start   :  STD_LOGIC  ; 
  COMPONENT Master_Controller  
    PORT ( 
      BurstCount  : in UNSIGNED (2 downto 0) ; 
      Reading  : out STD_LOGIC ; 
      AM_ReadData  : in std_logic_vector (31 downto 0) ; 
      FIFO_Almost_full  : in STD_LOGIC ; 
      WrFIFO  : out STD_LOGIC ; 
      AM_BurstCount  : out std_logic_vector (2 downto 0) ; 
      Reset_n  : in STD_LOGIC ; 
      AM_Read  : out STD_LOGIC ; 
      Clk  : in STD_LOGIC ; 
      AM_Address  : out std_logic_vector (31 downto 0) ; 
      AM_ReadDataValid  : in STD_LOGIC ; 
      Currently_writing  : in STD_LOGIC ; 
      WrData  : out std_logic_vector (31 downto 0) ; 
      AM_WaitRequest  : in STD_LOGIC ; 
      DataLength  : in UNSIGNED (31 downto 0) ; 
      Address  : in UNSIGNED (31 downto 0) ; 
      Start  : in STD_LOGIC ); 
  END COMPONENT ; 
BEGIN
  DUT  : Master_Controller  
    PORT MAP ( 
      BurstCount   => BurstCount  ,
      Reading   => Reading  ,
      AM_ReadData   => AM_ReadData  ,
      FIFO_Almost_full   => FIFO_Almost_full  ,
      WrFIFO   => WrFIFO  ,
      AM_BurstCount   => AM_BurstCount  ,
      Reset_n   => Reset_n  ,
      AM_Read   => AM_Read  ,
      Clk   => Clk  ,
      AM_Address   => AM_Address  ,
      AM_ReadDataValid   => AM_ReadDataValid  ,
      Currently_writing   => Currently_writing  ,
      WrData   => WrData  ,
      AM_WaitRequest   => AM_WaitRequest  ,
      DataLength   => DataLength  ,
      Address   => Address  ,
      Start   => Start   ) ; 



-- "Clock Pattern" : dutyCycle = 50
-- Start Time = 0 ns, End Time = 1 us, Period = 20 ns
  Process
	Begin
	 clk  <= '0'  ;
	wait for 10 ns ;
-- 10 ns, single loop till start period.
	for Z in 1 to 49
	loop
	    clk  <= '1'  ;
	   wait for 10 ns ;
	    clk  <= '0'  ;
	   wait for 10 ns ;
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
  Begin
  Reset_n  <= '1' ; 
  Address  <= (others => '0') ; 
	DataLength <= (others => '0') ; 
  BurstCount <= (others => '0') ; 
  Start <= '0';
	Currently_writing <= '1';
  FIFO_almost_full <= '0';
  AM_ReadData <= (others => '0') ;
  AM_ReadDataValid <='0';
  AM_WaitRequest <= '1';
  
  wait for 10 ns ;
  Reset_n  <= '0' ; 

	wait for 20 ns;
	Reset_n <= '1';
  Address  <= X"0000_0004";	-- Origin address from SDRAM     
  DataLength <= X"0000_0002";	-- Twice reading process
  BurstCount <= "100";		-- BurstCount = 4
  Start <= '1';
  Currently_writing <= '0';
	AM_ReadDataValid <= '0';
	
	wait for 20 ns;
	AM_WaitRequest <= '0';

	wait for 20 ns;   		-- Next reading process fron a differente base address
	Address  <= X"0000_0008";	-- Origin address from SDRAM     
	BurstCount <= "011";		-- BurstCount = 3         

	wait for 30 ns;
	AM_ReadData <= X"0000_0001";
	AM_ReadDataValid <= '1';
     
  wait for 20 ns;                -- Second, the length of lectures we want to do 
	AM_ReadData <= X"0000_0002";
	AM_ReadDataValid <= '1';

	--wait for 20 ns;
	--AM_ReadData <= X"0000_0000";
	--AM_ReadDataValid <= '0';

	wait for 20 ns;
	AM_ReadData <= X"0000_0003";
	AM_ReadDataValid <= '1';
	 
	wait for 20 ns;
	AM_ReadData <= X"0000_0004";
	AM_ReadDataValid <= '1';

	wait for 20 ns;
	AM_ReadData <= X"0000_0000";
	AM_ReadDataValid <= '0';
                      
	wait;
 End Process;
END;

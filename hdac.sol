/// This is made for hdac Hackerton in 2018.
/// Made by Team Block In
/// Ver 0.1
pragma solidity ^0.4.0;
import "./DateTime.sol";
contract hdac{

   struct IoTnet{
       address Admin;
       address[] PermittedUser;
       address[] PermittedDevice;
       uint numDevice;
       uint numPermittedUser;
   }

   struct Device{
       address DeviceAddress;
       bool State;
       string Name;
       string Type;
       uint StartTime;
       uint EndTime;
       uint UsageTime;
       uint Fee;
   }

   struct Home{
       address HomeOwner;
       IoTnet HomeNet;
       uint Index;
       bool OnMarket;
       uint Price;
       uint CheckinTime;
       uint CheckoutTime;
       uint UsageTime;
   }

   struct Customer{
       address CustomerAddress;
       uint Deposit;
       uint TotalPrice;
   }

   mapping(uint => Home) homes;
   mapping(address => Device) devices;
   mapping(address => Customer) customers;
   uint numHomes;
   uint public balance;
   address ContractOwner;
   function constuctor() public {
   numHomes = 1;
   balance = 0;
   ContractOwner = msg.sender;
   }

   function () payable public {
       customers[msg.sender] = Customer(msg.sender,msg.value,0);
       balance += msg.value;

   }

   function getMinute(uint _TimeStamp) public pure returns (uint)
   {
       return uint((_TimeStamp / 60) % 60);
   }

   function RegistHome(address _HomeOwner) public {
       if(msg.sender != ContractOwner)
       {
           return;
       }
       homes[numHomes] = Home(_HomeOwner,IoTnet(0,new address[](0),new address[](0),0,0),numHomes,false,0,0,0,0);
   }

   function OnSale(uint _HomeIndex, uint _Price) public
   {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].OnMarket = true;
       homes[_HomeIndex].Price = _Price;
   }

   function AddDevice(uint _HomeIndex, address _DeviceAddress, string _Name, string _Type, uint _Fee) public {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].HomeNet.PermittedDevice.push(_DeviceAddress);
       devices[_DeviceAddress] = Device(_DeviceAddress,false,_Name,_Type,0,0,0,_Fee);
       homes[_HomeIndex].HomeNet.numDevice++;
   }

   function GiveAdmin(uint _HomeIndex, address _To) public {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].HomeNet.Admin = _To;
   }

   function DelegatePermission(uint _HomeIndex, address _To) public {
       if(homes[_HomeIndex].HomeNet.Admin != msg.sender && homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].HomeNet.PermittedUser.push(_To);
   }

   function Checkin(uint _HomeIndex, address _To) public {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       if(homes[_HomeIndex].OnMarket == false)
       {
           return;
       }
       if(customers[_To].Deposit < 3 ether)
       {
           return;
       }
       DelegatePermission(_HomeIndex,_To);
       homes[_HomeIndex].OnMarket = false;
       homes[_HomeIndex].CheckinTime = now;
   }

   function Checkout(uint _HomeIndex) payable public {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].CheckoutTime = now;
       homes[_HomeIndex].UsageTime = homes[_HomeIndex].CheckoutTime - homes[_HomeIndex].CheckinTime;
   }

   function GetHome(uint _HomeIndex) public constant returns(address _HomeOwner, bool _OnMarket, uint _Price, uint _CheckinTime, uint _CheckoutTime, uint _UsageTime){
       _HomeOwner = homes[_HomeIndex].HomeOwner;
       _OnMarket = homes[_HomeIndex].OnMarket;
       _Price = homes[_HomeIndex].Price;
       _CheckinTime = homes[_HomeIndex].CheckinTime;
       _CheckoutTime = homes[_HomeIndex].CheckoutTime;
       _UsageTime = getMinute(_CheckoutTime - _CheckinTime);
   }

   function Initialize(uint _HomeIndex) public {
       homes[_HomeIndex].HomeNet.Admin = 0;
       homes[_HomeIndex].HomeNet.PermittedUser = new address[](0);
       homes[_HomeIndex].HomeNet.numPermittedUser = 0;
       homes[_HomeIndex].OnMarket = false;
       homes[_HomeIndex].CheckinTime = 0;
       homes[_HomeIndex].CheckoutTime = 0;
       homes[_HomeIndex].UsageTime = 0;
   }

   function GetCustomer(address _CustomerAddress) public constant returns (uint _Deposit, uint _TotalPrice) {
       _Deposit = customers[_CustomerAddress].Deposit;
       _TotalPrice = customers[_CustomerAddress].TotalPrice;
   }
}

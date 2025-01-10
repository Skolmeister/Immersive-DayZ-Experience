class CfgPatches
{
	class IDE_Items
	{
		units[]={};
		weapons[]={};
		requiredVersion=0.1;
		requiredAddons[]=
		{
			"DZ_Gear_Containers"  
		};
	};
};
class CfgMods
{
	class IDE
	{
		dir="IDE/Items";
		picture=""; 
		action="";
		hideName=1;
		hidePicture=1;
		name="IDE";
		credits=""; 
		author="Malerion";
		authorID="0";  
		version="1.0";
		extra=0;
		type="mod";
		dependencies[]=
		{
			"Game",
			"World",
			"Mission"
		};
		class defs
		{
			class gameScriptModule
			{
				value="";
				files[]=
				{
					"IDE/Scripts/3_Game"
				};
			};
			class worldScriptModule
			{
				value="";
				files[]=
				{
					"IDE/Scripts/4_World"
				};
			};
			class missionScriptModule
			{
				value="";
				files[]=
				{
					"IDE/Scripts/5_Mission"
				};
			};
		};
	};
};
class CfgVehicles
{
	class Container_Base;
	class FirstAidKit: Container_Base
	{
		scope=2;
		displayName="$STR_IDE_CfgVehicles_FirstAidKit0";
		itemSize[]={3,3};
		itemsCargoSize[]={5,5};
		inventorySlot[]=
		{
			"Belt_Left"
		};
		hiddenSelections[]=
		{
			"zbytek"
		};
		hiddenSelectionsTextures[]=
		{
			"\dz\gear\containers\data\firstaidkit_co.paa"
		};
	};
	class FirstAidKit_Black: FirstAidKit
	{
		scope=2;
		hiddenSelectionsTextures[]=
		{
			"\IDE\data\firstaidkit_Black_co.paa"
		};
	};
	class Bear_ColorBase;
	class Bear_Black: Bear_ColorBase
	{
		scope=2;
		hiddenSelectionsTextures[]=
		{
			"\IDE\data\teddybear_black_co.paa"
		};
	};
};


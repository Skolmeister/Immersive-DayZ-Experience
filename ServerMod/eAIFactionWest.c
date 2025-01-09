modded class eAIFactionWest
{
	override bool IsFriendly(notnull eAIFaction other)
	{
		if (other.IsInherited(eAIFactionWest)) return true;
		if (other.IsInherited(eAIFactionCivilian)) return true;
		if (other.IsInherited(eAIFactionSurvivors)) return true;
		if (other.IsPassive()) return true;
		return false;
	}
};

[eAIRegisterFaction(eAIFactionInvincibleWestGuards)]
class eAIFactionInvincibleWestGuards : eAIFaction
{
	void eAIFactionInvincibleWestGuards()
	{
		m_Name = "Invincible West Guards";
		m_Loadout = "WestLoadout";
		m_IsGuard = true;
		m_IsInvincible = true;
	}
	override bool IsFriendly(notnull eAIFaction other)
	{
		if (other.IsInherited(eAIFactionCivilian)) return true;
		if (other.IsInherited(eAIFactionWest)) return true;
		if (other.IsInherited(eAIFactionSurvivors)) return true;
		if (other.IsPassive()) return true;
		if (other.IsGuard()) return true;
		return false;
	}
};

[eAIRegisterFaction(eAIFactionWestGuards)]
class eAIFactionWestGuards : eAIFaction
{
	void eAIFactionWestGuards()
	{
		m_Name = "West Guards";
		m_Loadout = "WestLoadout";
		m_IsGuard = true;
	}
	override bool IsFriendly(notnull eAIFaction other)
	{
		if (other.IsInherited(eAIFactionCivilian)) return true;
		if (other.IsInherited(eAIFactionWest)) return true;
		if (other.IsInherited(eAIFactionSurvivors)) return true;
		if (other.IsPassive()) return true;
		if (other.IsGuard()) return true;
		return false;
	}
};
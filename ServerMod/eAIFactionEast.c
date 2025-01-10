modded class eAIFactionEast
{
	override bool IsFriendly(notnull eAIFaction other)
	{
		if (other.IsInherited(eAIFactionEast)) return true;
		if (other.IsInherited(eAIFactionCivilian)) return true;
		if (other.IsInherited(eAIFactionSurvivors)) return true;
		if (other.IsPassive()) return true;
		return false;
	}
};

[eAIRegisterFaction(eAIFactionInvincibleEastGuards)]
class eAIFactionInvincibleEastGuards : eAIFaction
{
	void eAIFactionInvincibleEastGuards()
	{
		m_Name = "Invincible East Guards";
		m_Loadout = "EastLoadout";
		m_IsGuard = true;
		m_IsInvincible = true;
	}
	override bool IsFriendly(notnull eAIFaction other)
	{
		if (other.IsInherited(eAIFactionCivilian)) return true;
		if (other.IsInherited(eAIFactionEast)) return true;
		if (other.IsInherited(eAIFactionSurvivors)) return true;
		if (other.IsPassive()) return true;
		if (other.IsGuard()) return true;
		return false;
	}
};

[eAIRegisterFaction(eAIFactionEastGuards)]
class eAIFactionEastGuards : eAIFaction
{
	void eAIFactionEastGuards()
	{
		m_Name = "East Guards";
		m_Loadout = "EastLoadout";
		m_IsGuard = true;
	}
	override bool IsFriendly(notnull eAIFaction other)
	{
		if (other.IsInherited(eAIFactionCivilian)) return true;
		if (other.IsInherited(eAIFactionEast)) return true;
		if (other.IsInherited(eAIFactionSurvivors)) return true;
		if (other.IsPassive()) return true;
		if (other.IsGuard()) return true;
		return false;
	}
};
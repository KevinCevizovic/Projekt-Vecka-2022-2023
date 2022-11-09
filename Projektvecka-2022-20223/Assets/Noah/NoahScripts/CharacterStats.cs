using UnityEngine;

public class CharacterStats : MonoBehaviour
{
    public float maxHealth = 100f;
    public float CurrentHealth { get; private set; }

    public Stat damage;

    public Stat armor;

    private void Awake()
    {
        CurrentHealth = maxHealth;
    }
}

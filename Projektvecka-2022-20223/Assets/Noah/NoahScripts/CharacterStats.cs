using UnityEngine;

public class CharacterStats : MonoBehaviour
{
    public float maxHealth = 100f;
    public float currentHealth { get; private set; }

    public Stat damage;

    public Stat armor;

    private void Awake()
    {
        currentHealth = maxHealth;
    }
}

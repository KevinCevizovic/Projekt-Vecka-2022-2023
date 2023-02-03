using UnityEngine;
using UnityEngine.InputSystem;


public class Health : MonoBehaviour
{
    [SerializeField] private float maxHealth = 100f;
    public float CurrentHealth { get; private set; }

    public float damage;

    private void Awake()
    {
        CurrentHealth = maxHealth;
    }

    public void TakingDamage(float damage)
    {
        CurrentHealth -= damage;
        print("Damage working");
    }
}

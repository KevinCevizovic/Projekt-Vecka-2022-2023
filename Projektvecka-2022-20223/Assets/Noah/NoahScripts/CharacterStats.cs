using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(CapsuleCollider))]
public class CharacterStats : MonoBehaviour
{
    [SerializeField] private float maxHealth = 100f;
    public float CurrentHealth { get; private set; }

    public Stat damage;
    public Stat armor;

    private void Update()
    {
        if (CurrentHealth <= 0)
        {
            CurrentHealth = 0;
            Dead();
        }
    }

    public void TakingDamage(int damage)
    {
        if(CurrentHealth <= 0)
        {
            print("Dead");
        }

        CurrentHealth -= damage;
        print("Damage working");

        damage -= armor.GetValue();
        damage = Mathf.Clamp(damage, 0, int.MaxValue);
    }

    private void Awake()
    {
        CurrentHealth = maxHealth;
    }

    public virtual void Dead()
    {
        print("You died");
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Enemy")
        {
            CharacterStats playerStats = other.GetComponent<CharacterStats>();

            if (playerStats != null)
            {
                Dead();
            }
        }
    }
}

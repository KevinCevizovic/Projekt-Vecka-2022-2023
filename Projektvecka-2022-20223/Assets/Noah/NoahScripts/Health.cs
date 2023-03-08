using UnityEngine;
using UnityEngine.UI;

public class Health : MonoBehaviour
{
    [SerializeField] private float maxHealth = 100f;
    [SerializeField] private Image healthBarImage;
    [field: SerializeField] public float CurrentHealth { get; private set; }

    private void Start()
    {
        CurrentHealth = maxHealth;
        UpdateHealthBar();
    }

    public void UpdateHealthBar()
    {
        try
        {
            healthBarImage.fillAmount = Mathf.Clamp(CurrentHealth / maxHealth, 0, 1f);
        }
        catch
        {
            Debug.Log("I don't have the healthBarImage");
        }
        
    }

    public void TakingDamage(float damage)
    {
        CurrentHealth -= damage;
        UpdateHealthBar();
        CheckDeath();
    }

    public void CheckDeath()
    {
        if (CurrentHealth <= 0)
        {
            gameObject.SetActive(false);
        }
    }

    public void Heal(float amount)
    {
        CurrentHealth += amount;
        if (CurrentHealth > maxHealth)
        {
            CurrentHealth = maxHealth;
        }
        UpdateHealthBar();
    }
}

using UnityEngine;
using UnityEngine.UI;

public class Health : MonoBehaviour
{
    public float maxHealth = 100f;
    [SerializeField] private Image healthBarImage;
    [SerializeField] private GameObject healthBarImageAI;
    [field: SerializeField] public float CurrentHealth { get; private set; }

    private void Start()
    {
        CurrentHealth = maxHealth;
        //UpdateHealthBar();
    }

    public void UpdateHealthBar()
    {
        if (gameObject.CompareTag("Player"))
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
        else
        {
            GetComponent<EnemyAI>().healthBarImageSpawned.GetComponentInChildren<Image>().fillAmount = Mathf.Clamp(CurrentHealth / maxHealth, 0, 1f);
        }
    }

    public void TakingDamage(float damage)
    {
        CurrentHealth -= damage;
        CheckDeath();
        UpdateHealthBar();
    }

    public void CheckDeath()
    {
        if (CurrentHealth <= 0)
        {
            GetComponent<EnemyAI>().healthBarImageSpawned.SetActive(false);
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

using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

public class HealthPotionScript : MonoBehaviour
{
    public int maxHealthPotionAmount;

    [SerializeField] private int healthPotionAmount;
    public int HealthPotionAmount
    {
        get { return healthPotionAmount; }
        private set { healthPotionAmount = Mathf.Clamp(value, 0, maxHealthPotionAmount); }
    }
    [SerializeField] float healingStrength;

    private Health playerHealth;

    [SerializeField] private TMP_Text text;

    private void Awake()
    {
        playerHealth = GetComponent<Health>();
    }

    private void Start()
    {
        UpdateUI();
    }

    public void AddAmount(int amount)
    {
        HealthPotionAmount += amount;

        UpdateUI();
    }

    public void RemoveAmount(int amount)
    {
        healthPotionAmount -= amount;

        UpdateUI();
    }

    public void UsePotion()
    {
        if (HealthPotionAmount <= 0) return;

        RemoveAmount(1);
        playerHealth.Heal(healingStrength);

        UpdateUI();
    }

    public void UsePotion(InputAction.CallbackContext ctx)
    {
        if (HealthPotionAmount <= 0 || !ctx.started) return;

        RemoveAmount(1);
        playerHealth.Heal(healingStrength);

        UpdateUI();
    }

    public void UpdateUI()
    {
        if (text != null)
            text.text = healthPotionAmount.ToString();
    }
}
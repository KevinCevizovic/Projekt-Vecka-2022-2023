using UnityEngine;

public class HealthPotionAmount : MonoBehaviour
{
    public int healthPotionAmount = 0;

    public void AddAmount(int amount)
    {
        if(healthPotionAmount < 0) { return; }
        healthPotionAmount += amount;
    }
    
    public void RemoveAmount(int amount)
    {
        if (healthPotionAmount == 0)
            return;
        if (GetComponent<Health>().CurrentHealth > GetComponent<Health>().maxHealth)
        {
            healthPotionAmount -= amount;
            GetComponent<Health>().Heal(40f);
        }
    }
}

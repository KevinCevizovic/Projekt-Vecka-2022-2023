using UnityEngine;

public class Collectable : MonoBehaviour
{
    private int amountHealth = 1;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("Collided with player");
            other.GetComponent<HealthPotionAmount>().AddAmount(amountHealth);
            Destroy(gameObject);
        }
    }
}
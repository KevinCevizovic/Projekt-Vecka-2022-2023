using UnityEngine;

public class Market : MonoBehaviour
{
    Wallet wallet;
    HealthPotionScript healthPotionScript;
    public GameObject UIShop;

    private void Awake()
    {
        wallet = GameObject.FindGameObjectWithTag("Player").GetComponent<Wallet>();
        healthPotionScript = GameObject.FindGameObjectWithTag("Player").GetComponent<HealthPotionScript>();
    }

    private void OnTriggerEnter(Collider other)
    {
        UIShop.SetActive(true);
    }

    private void OnTriggerExit(Collider other)
    {
        UIShop.SetActive(false);
    }

    public void BuyHealthPotion()
    {
        if (wallet.coins < 10)
        {
            Debug.Log("You're poor");
            return;
        }
        wallet.AddCoins(-10);
        healthPotionScript.AddAmount(1);
    }
}
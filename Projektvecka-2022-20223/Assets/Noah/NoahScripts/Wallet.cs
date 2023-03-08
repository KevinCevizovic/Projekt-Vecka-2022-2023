using UnityEngine;
using TMPro;

public class Wallet : MonoBehaviour
{
    public int coins = 0;

    public static Wallet instance;
    [SerializeField]private TMP_Text coinText;

    private void Start()
    {
        coinText.text = "x " + coins.ToString();
    }
    public void AddCoins(int add)
    {
        //Debug.Log("Added amount: " + add);
        coins += add;

        UpdateUI();
    }

    public void UpdateUI()
    {
        if (coinText != null)
            coinText.text = "x " + coins.ToString();
    }
}
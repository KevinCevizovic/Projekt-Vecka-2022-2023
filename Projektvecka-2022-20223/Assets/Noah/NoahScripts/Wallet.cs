using UnityEngine;

public class Wallet : MonoBehaviour
{
    public int coins;

    public void AddCoins(int add)
    {
        Debug.Log("Added amount: " + add);
        coins += add;
    }
}
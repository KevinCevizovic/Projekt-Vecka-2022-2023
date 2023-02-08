using UnityEngine;

public class Wallet : MonoBehaviour
{
    public int coins;

    public void AddCoins(int add)
    {
        coins += add;
    }
}
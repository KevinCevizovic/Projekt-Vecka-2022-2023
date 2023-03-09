using UnityEngine;

[CreateAssetMenu(fileName = "New Coin", menuName = "Collectible/Coin")]
public class Coin : Collectible
{
    public override void Collect(GameObject _object)
    {
        Debug.Log($"{_object.name} collected {name}");
        Wallet wallet = _object.GetComponent<Wallet>();
        if (wallet != null)
            wallet.AddCoins(1);
    }
}
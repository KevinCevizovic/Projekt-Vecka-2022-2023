using UnityEngine;

[CreateAssetMenu(fileName = "New Coin", menuName = "Collectible/Coin")]
public class Coin : Collectible
{
    public override void Activate(GameObject _object)
    {
        Debug.Log($"{_object.name} collected {name}");
    }
}
using UnityEngine;

public class CoinScript : CollectibleScript
{
    public override void Activate(GameObject _object)
    {
        Debug.Log($"{_object.name} collected {transform.parent.name}");
    }
}
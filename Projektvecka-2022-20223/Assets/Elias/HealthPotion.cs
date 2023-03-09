using UnityEngine;

[CreateAssetMenu(fileName = "New HealthPotion", menuName = "Collectible/HealthPotion")]
public class HealthPotion : Collectible
{
    public override void Collect(GameObject _object)
    {
        _object.GetComponent<HealthPotionScript>().AddAmount(1);
    }
}
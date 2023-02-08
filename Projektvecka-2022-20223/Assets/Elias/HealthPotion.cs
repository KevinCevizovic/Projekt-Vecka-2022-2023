using UnityEngine;

[CreateAssetMenu(fileName = "New HealthPotion", menuName = "Collectible/HealthPotion")]
public class HealthPotion : Collectible
{
    public float potency = 10f;

    public override void Activate(GameObject _object)
    {
        if (_object.TryGetComponent(out Health healhScript))
            healhScript.Heal(potency);
    }
}
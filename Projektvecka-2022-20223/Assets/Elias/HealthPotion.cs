using UnityEngine;

public class HealthPotion : CollectibleScript
{
    public float potency = 10f;

    public override void Activate(GameObject _object)
    {
        if (_object.TryGetComponent(out Health healhScript))
            healhScript.Heal(potency);
    }
}
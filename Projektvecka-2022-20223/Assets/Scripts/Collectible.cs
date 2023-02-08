using UnityEngine;

public abstract class Collectible : Item
{
    /// <summary> Called when picked up </summary>
    public abstract void Activate(GameObject _object);
}
using UnityEngine;

public abstract class Collectible : Item
{
    /// <summary> Called when picked up, object parameter is the object that collected </summary>
    public abstract void Collect(GameObject _object);
}
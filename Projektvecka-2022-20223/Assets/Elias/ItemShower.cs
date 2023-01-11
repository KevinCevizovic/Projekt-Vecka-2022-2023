using UnityEngine;

public class ItemShower : MonoBehaviour
{
    public Item item;

    private void Start()
    {
        ChangeObject(item);
    }

    public void ChangeObject(Item _object)
    {
        item = _object;

        foreach (Transform child in transform)
            Destroy(child.gameObject);

        if (item is not null && item._object is not null)
            Instantiate(item._object, transform);
    }
}
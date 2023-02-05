using UnityEngine;

public class ItemShower : MonoBehaviour
{
    public Item item;

    new private Collider collider;

    private void Awake()
    {
        collider = GetComponent<Collider>();
    }

    private void Start()
    {
        ChangeObject(item);
    }

    public void ChangeObject(Item _object)
    {
        item = _object;

        foreach (Transform child in transform)
            Destroy(child.gameObject);

        if (item != null && item._object != null)
        {
            Instantiate(item._object, transform);

            foreach (Collider collider in GetComponentsInChildren<Collider>())
                if (collider != this.collider)
                    Destroy(collider);
        }

        if (item != null)
            name = $"{item.name}";
        else name = $"Empty";
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawWireCube(transform.position, transform.lossyScale * 2f);
    }
}
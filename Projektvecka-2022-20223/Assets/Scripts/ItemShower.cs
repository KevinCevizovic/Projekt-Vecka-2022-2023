using UnityEngine;

public class ItemShower : MonoBehaviour
{
    public Item item;

    [SerializeField] bool keepCollider = false;

    new private Collider collider;

    private void OnValidate()
    {
        name = item != null ? item.name + "(Itemshower)" : "Empty(Itemshower)"; // changes name to item name
    }

    private void Awake()
    {
        collider = GetComponent<Collider>();
    }

    private void Start()
    {
        if (item != null && item._object != null)
            ChangeObject(item, !keepCollider);
        else Debug.Log("Item is null or doesnt have a object in " + gameObject);
    }

    public void ChangeObject(Item item, bool removeCollider = false)
    {
        this.item = item;
        keepCollider = !removeCollider;

        foreach (Transform child in transform)
            Destroy(child.gameObject);

        if (item != null && item._object != null)
        {
            Instantiate(item._object, transform);

            if (removeCollider)
                foreach (Collider collider in GetComponentsInChildren<Collider>())
                    if (collider != this.collider)
                        Destroy(collider);
        }

        name = item != null ? item.name + "(Itemshower)" : "Empty(Itemshower)"; // changes name to item name or Empty
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawWireCube(transform.position, transform.lossyScale * 2f);
    }
}
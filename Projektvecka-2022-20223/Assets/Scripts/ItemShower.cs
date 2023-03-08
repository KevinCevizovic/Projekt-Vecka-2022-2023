using UnityEngine;

public class ItemShower : MonoBehaviour
{
    [field: SerializeField] public Item Item { get; private set; }

    [SerializeField] bool keepCollider = false;

    new private Collider collider;

    private void OnValidate()
    {
        name = Item != null ? Item.name + "(Itemshower)" : "Empty(Itemshower)"; // changes name to item name
    }

    private void Awake()
    {
        collider = GetComponent<Collider>();
    }

    private void Start()
    {
        if (Item != null && Item._object != null)
            ChangeObject(Item, !keepCollider);
        else Debug.Log("Item is null or doesnt have a object in " + gameObject);
    }

    public void ChangeObject(Item item, bool removeCollider = false)
    {
        Item = item;

        name = item != null ? item.name + "(Itemshower)" : "Empty(Itemshower)"; // changes name to item name or Empty

        if (!Application.isPlaying) return; // so it doesnt try to destroy and instantiate stuff in editor

        keepCollider = !removeCollider;

        // remove already existing objects
        foreach (Transform child in transform)
            Destroy(child.gameObject);

        // create object
        if (item != null && item._object != null) // item and object isnt null
        {
            Instantiate(item._object, transform);

            if (removeCollider)
                foreach (Collider collider in GetComponentsInChildren<Collider>())
                    if (collider != this.collider)
                        Destroy(collider);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;

        if (collider != null)
            Gizmos.DrawWireCube(collider.bounds.center, collider.bounds.size);
    }
}
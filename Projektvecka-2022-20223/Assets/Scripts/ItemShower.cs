using UnityEngine;

public class ItemShower : MonoBehaviour
{
    public Item item;

    new private Collider collider;

    [SerializeField] bool held = false;

    private void OnValidate()
    {
        name = item != null ? item.name : "Empty"; // changes name to item name
    }

    private void Awake()
    {
        collider = GetComponent<Collider>();
    }

    private void Start()
    {
        ChangeObject(item, held); // when implement weapons
    }

    public void ChangeObject(Item _object, bool removeCollider = false)
    {
        item = _object;

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

        name = item != null ? item.name : "Empty"; // changes name to item name or Empty
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawWireCube(transform.position, transform.lossyScale * 2f);
    }
}
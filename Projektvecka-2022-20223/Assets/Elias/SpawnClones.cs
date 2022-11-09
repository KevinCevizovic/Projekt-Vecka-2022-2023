using UnityEngine;

public class SpawnClones : MonoBehaviour
{
    private void OnValidate()
    {
        InvokeRepeating(nameof(SpawnClone), 1f, 1f);
    }

    private void SpawnClone()
    {
        var clone = Instantiate(gameObject);
        clone.name = gameObject.name;
    }
}
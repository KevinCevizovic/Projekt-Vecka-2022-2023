using UnityEngine;

public class SpawnClones : MonoBehaviour
{
    private void OnValidate()
    {
        InvokeRepeating(nameof(SpawnClone), 0f, 0.1f);
    }

    private void SpawnClone()
    {
        var clone = Instantiate(gameObject);
        clone.name = gameObject.name;
    }
}
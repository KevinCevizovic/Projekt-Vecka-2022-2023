using System.Linq;
using UnityEditor;
using UnityEngine;

public class SpawnClones : MonoBehaviour
{
#if UNITY_EDITOR
    [CustomEditor(typeof(SpawnClones))]
    public class SpawnClonesEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            SpawnClones spawnClonesScript = (SpawnClones)target;

            if (GUILayout.Button("Stop all spawning", GUILayout.MaxWidth(120)))
                spawnClonesScript.StopAllSpawning();
            if (GUILayout.Button("Remove all other clones", GUILayout.MaxWidth(150)))
                spawnClonesScript.RemoveAllOtherClones();
            if (GUILayout.Button("Remove all SpawnClones scripts", GUILayout.MaxWidth(200)))
                spawnClonesScript.RemoveAllSpawnClonesScripts();

            base.OnInspectorGUI();
        }
    }
#endif

    private void OnValidate()
    {
        Invoke(nameof(SpawnClone), 0.5f);
    }

    private void SpawnClone()
    {
        var clone = Instantiate(gameObject);
        clone.name = gameObject.name;

        clone.GetComponent<SpawnClones>().Invoke(nameof(SpawnClone), 0.5f);
    }

    private void StopAllSpawning()
    {
        var clones = FindObjectsOfType<SpawnClones>();

        foreach (var clone in clones)
            clone.StopAllCoroutines();
    }

    private void RemoveAllOtherClones()
    {
        var clones = FindObjectsOfType<SpawnClones>();

        for (int i = 0; i < clones.Length; i++)
            if (clones[i].gameObject == gameObject)
                clones = clones.Where((source, index) => index != i).ToArray();

        foreach (var clone in clones)
            DestroyImmediate(clone.gameObject);
    }

    private void RemoveAllSpawnClonesScripts()
    {
        var clones = FindObjectsOfType<SpawnClones>();

        foreach (var clone in clones)
            DestroyImmediate(clone);
    }
}
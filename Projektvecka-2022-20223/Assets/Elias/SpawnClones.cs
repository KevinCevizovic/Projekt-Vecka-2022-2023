using System.Linq;
using UnityEditor;
using UnityEngine;

public class SpawnClones : MonoBehaviour
{
#if UNITY_EDITOR
    [CustomEditor(typeof(SpawnClones))]
    public class GridScriptEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            SpawnClones spawnClonesScript = (SpawnClones)target;

            if (spawnClonesScript == null) return;

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
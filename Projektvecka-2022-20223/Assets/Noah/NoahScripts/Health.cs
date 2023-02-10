//using UnityEditor;
using UnityEngine;

public class Health : MonoBehaviour
{
//#if UNITY_EDITOR
//    [CustomEditor(typeof(Health))]
//    public class HealthEditor : Editor
//    {
//        public override void OnInspectorGUI()
//        {
//            base.OnInspectorGUI();

//            Health script = (Health)target;

//            // health text
//            EditorGUILayout.BeginHorizontal();
//            EditorGUILayout.LabelField("Current Health", EditorStyles.label, GUILayout.MaxWidth(120));
//            EditorGUILayout.LabelField(script.CurrentHealth.ToString(), GUILayout.MaxWidth(200));
//            EditorGUILayout.EndHorizontal();
//        }
//    }
//#endif

    [SerializeField] private float maxHealth = 100f;

    public float CurrentHealth { get; private set; }

    private void Start()
    {
        CurrentHealth = maxHealth;
    }

    public void TakingDamage(float damage)
    {
        CurrentHealth -= damage;
        CheckDeath();
    }

    public void CheckDeath()
    {
        if (CurrentHealth <= 0)
        {
            gameObject.SetActive(false);
        }
    }

    public void Heal(float amount)
    {
        CurrentHealth += amount;

        if (CurrentHealth > maxHealth)
        {
            CurrentHealth = maxHealth;
        }
    }
}

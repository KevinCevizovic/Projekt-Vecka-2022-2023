using UnityEngine;
using TMPro;

public class PickupCanvasScript : MonoBehaviour
{
    private TMP_Text text;
    [SerializeField] private Vector3 offset = new Vector3(0f, 3f, 0f);

    private void Awake()
    {
        text = GetComponentInChildren<TMP_Text>();
    }

    public void ChangeText(string text) => this.text.text = text;

    public void ShowAndSetPosition(Vector3 position)
    {
        gameObject.SetActive(true);
        transform.position = position + offset;
    }

    public void Hide() => gameObject.SetActive(false);
}